import React, { useEffect, useState } from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AppText } from '../../core/components/AppText';
import { AppTextField } from '../../core/components/AppTextField';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { TextButton } from '../../core/components/TextButton';
import { AuthError, authErrorKey } from '../../data/repositories/authErrors';
import { theme } from '../../core/theme';
import type { AuthStackParamList } from '../../navigation/AuthStack';
import { useAuth } from './authController';
import {
  validateEmail,
  validateName,
  validatePassword,
} from './authValidation';

type Props = NativeStackScreenProps<AuthStackParamList, 'SignUp'>;
type FieldErrors = {
  name: AuthError | null;
  email: AuthError | null;
  password: AuthError | null;
};

export function SignUpScreen({ navigation }: Props): React.JSX.Element {
  const { signUp, isLoading, error, clearError } = useAuth();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({
    name: null,
    email: null,
    password: null,
  });

  // Start without an error left over from the other auth screen.
  useEffect(() => {
    clearError();
  }, [clearError]);

  const submit = () => {
    if (isLoading) {
      return;
    }
    const errors = {
      name: validateName(name),
      email: validateEmail(email),
      password: validatePassword(password),
    };
    setFieldErrors(errors);
    if (errors.name || errors.email || errors.password) {
      return;
    }
    signUp({ email, password, displayName: name });
  };

  return (
    <ScrollView
      contentContainerStyle={styles.container}
      keyboardShouldPersistTaps="handled"
    >
      <AppText translationKey="authSignUpTitle" style={styles.title} />
      <AppTextField
        labelKey="authDisplayNameLabel"
        errorKey={fieldErrors.name ? authErrorKey(fieldErrors.name) : undefined}
        value={name}
        onChangeText={setName}
        autoComplete="name"
        returnKeyType="next"
      />
      <AppTextField
        labelKey="authEmailLabel"
        errorKey={
          fieldErrors.email ? authErrorKey(fieldErrors.email) : undefined
        }
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        autoCorrect={false}
        autoComplete="email"
        returnKeyType="next"
      />
      <AppTextField
        labelKey="authPasswordLabel"
        errorKey={
          fieldErrors.password ? authErrorKey(fieldErrors.password) : undefined
        }
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        autoCapitalize="none"
        autoComplete="new-password"
        returnKeyType="done"
        onSubmitEditing={submit}
      />
      {error ? (
        <AppText
          translationKey={authErrorKey(error)}
          style={styles.formError}
        />
      ) : null}
      <PrimaryButton
        labelKey="authSignUpButton"
        loading={isLoading}
        onPress={submit}
      />
      <TextButton
        labelKey="authGoToLogin"
        disabled={isLoading}
        onPress={() => navigation.navigate('Login')}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.background,
    flexGrow: 1,
    gap: theme.spacing.md,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  title: {
    fontSize: theme.fontSizes.title,
    fontWeight: '700',
    marginBottom: theme.spacing.md,
    textAlign: 'center',
  },
  formError: { color: theme.colors.error, textAlign: 'center' },
});
